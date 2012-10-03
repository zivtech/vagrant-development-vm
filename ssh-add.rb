require 'vagrant'
require 'net/ssh'

module ZivtechKeyAdder
  class Middleware
   def initialize(app, env, options = {})
      @app = app
      @env = env
      # @vm  = env[:vm]
      # See that our plugin is being loaded.
      puts 'initialize'
    end

    def execute
      agent = Net::SSH::Authentication::Agent.connect()
      agent.identities().each do |identity|
        if identity.comment.scan('id_rsa').length == 1
          # env[:ui].info "RSA key found, assuming it is safe for use."
          return
        end
      end
      # If we are still running, no rsa key was found. Add one
      # env[:ui].info "No RSA key found, running ssh-add to add one."
      Kernel.system "ssh-add"
    end
  end
end

module VagrantPlugins
  module CommandFetcherSSH
    class Command < Vagrant::Command::SSH
      def execute
        ZivtechKeyAdder::Middleware::call()
        parent.execute()
      end
    end
  end
end

Vagrant.commands.register(:ssh) { ZivtechKeyAdder::Middleware }

# Vagrant.actions[:ssh].insert_before(1, ZivtechKeyAdder::Middleware)
# puts Vagrant.commands[:ssh] =
=begin
class DignioDeployCommand < Vagrant::Command::Base
  def execute
    agent = Net::SSH::Authentication::Agent.connect()
    agent.identities().each do |identity|
      if identity.comment.scan('id_rsa').length == 1
        return
      end
    end
    # If we are still running, no rsa key was found. Add one
    Kernel.system "ssh-add"
  end
end
Vagrant.commands.register(:ssher) { DignioDeployCommand }
=end
