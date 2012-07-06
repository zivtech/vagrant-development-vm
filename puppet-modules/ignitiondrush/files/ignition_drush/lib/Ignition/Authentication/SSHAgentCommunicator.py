#! /usr/bin/python2.4
import cStringIO
import os
import re
import sha
import socket
import struct
import sys
import base64
import hashlib
import json

SSH2_AGENTC_REQUEST_IDENTITIES = 11
SSH2_AGENT_IDENTITIES_ANSWER = 12
SSH2_AGENTC_SIGN_REQUEST = 13
SSH2_AGENT_SIGN_RESPONSE = 14
SSH_AGENT_FAILURE = 5

def RecvAll(sock, size):
  if size == 0:
    return ''
  assert size >= 0
  if hasattr(sock, 'recv'):
    recv = sock.recv
  else:
    recv = sock.read
  data = recv(size)
  if len(data) >= size:
    return data
  assert data, 'unexpected EOF'
  output = [data]
  size -= len(data)
  while size > 0:
    output.append(recv(size))
    assert output[-1], 'unexpected EOF'
    size -= len(output[-1])
  return ''.join(output)

def RecvU32(sock):
  return struct.unpack('>L', RecvAll(sock, 4))[0]

def RecvStr(sock):
  return RecvAll(sock, RecvU32(sock))

def AppendStr(ary, data):
  assert isinstance(data, str)
  ary.append(struct.pack('>L', len(data)))
  ary.append(data)

if __name__ == '__main__':

  if len(sys.argv) > 1:
    # There is no limitation on the message size (because ssh-agent will
    # SHA-1 it before signing anyway).
    msg_to_sign = sys.argv[1]

  # Connect to ssh-agent.
  assert 'SSH_AUTH_SOCK' in os.environ, (
      'ssh-agent not found, set SSH_AUTH_SOCK')
  sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM, 0)
  sock.connect(os.getenv('SSH_AUTH_SOCK'))

  # Get list of public keys, and find our key.
  sock.sendall('\0\0\0\1\v') # SSH2_AGENTC_REQUEST_IDENTITIES
  response = RecvStr(sock)
  resf = cStringIO.StringIO(response)
  assert RecvAll(resf, 1) == chr(SSH2_AGENT_IDENTITIES_ANSWER)
  num_keys = RecvU32(resf)
  assert num_keys < 2000  # A quick sanity check.
  assert num_keys, 'no keys have_been added to ssh-agent'
  matching_keys = []
  for i in xrange(num_keys):
    key = RecvStr(resf)
    comment = RecvStr(resf)
    if key.startswith('\x00\x00\x00\x07ssh-rsa\x00\x00'):
      matching_keys.append(key)
  assert '' == resf.read(1), 'EOF expected in resf'
  assert matching_keys, 'no keys in ssh-agent with comment %r' % ssh_key_comment
  assert matching_keys[0].startswith('\x00\x00\x00\x07ssh-rsa\x00\x00'), (
      'non-RSA key in ssh-agent with comment %r' % ssh_key_comment)
  keyf = cStringIO.StringIO(matching_keys[0][11:])
  public_exponent = int(RecvStr(keyf).encode('hex'), 16)
  modulus_str = RecvStr(keyf)
  modulus = int(modulus_str.encode('hex'), 16)
  assert '' == keyf.read(1), 'EOF expected in keyf'

  # Ask ssh-agent to sign with our key.
  request_output = [chr(SSH2_AGENTC_SIGN_REQUEST)]
  AppendStr(request_output, matching_keys[0])
  AppendStr(request_output, msg_to_sign)
  request_output.append(struct.pack('>L', 0))  # flags == 0
  full_request_output = []
  AppendStr(full_request_output, ''.join(request_output))
  full_request_str = ''.join(full_request_output)
  sock.sendall(full_request_str)
  response = RecvStr(sock)
  resf = cStringIO.StringIO(response)
  assert RecvAll(resf, 1) == chr(SSH2_AGENT_SIGN_RESPONSE)
  signature = RecvStr(resf)
  assert '' == resf.read(1), 'EOF expected in resf'
  assert signature.startswith('\0\0\0\7ssh-rsa\0\0')
  sigf = cStringIO.StringIO(signature[11:])
  signed_value = int(RecvStr(sigf).encode('hex'), 16)
  assert '' == sigf.read(1), 'EOF expected in sigf'


  # TODO: Enable this command to somehow pass back the public key's fingerprint.
  fp_plain = hashlib.md5(matching_keys[0]).hexdigest()
  fingerprint = ':'.join(a+b for a,b in zip(fp_plain[::2], fp_plain[1::2]))
  base64_signature = base64.b64encode(signature[15:])
  print >>sys.stdout, json.dumps({'signature': base64_signature, 'fingerprint': fingerprint})
  
  # Verify the signature.
  decoded_value = pow(signed_value, public_exponent, modulus)
  decoded_hex = '%x' % decoded_value
  if len(decoded_hex) & 1:
    decoded_hex = '0' + decoded_hex
  decoded_str = decoded_hex.decode('hex')
  assert len(decoded_str) == len(modulus_str) - 2  # e.g. (255, 257)
  assert re.match(r'\x01\xFF+\Z', decoded_str[:-36]), 'bad padding found'
  expected_sha1_hex = decoded_hex[-40:]
  msg_sha1_hex = sha.sha(msg_to_sign).hexdigest()
  assert expected_sha1_hex == msg_sha1_hex, 'bad signature (SHA1 mismatch)'
  print >>sys.stderr, msg_sha1_hex
  print >>sys.stderr, 'info: good signature'
