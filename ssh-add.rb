require 'vagrant'
require 'net/ssh'

module ZivtechKeyAdder
  class Middleware < Vagrant::Command::SSH
   def initialize(app, env, options = {})
      @app = app
      @env = env
    end

    def execute
      with_target_vms(nil) do |vm|
        agent = Net::SSH::Authentication::Agent.connect()
        rsaFound = false
        agent.identities().each do |identity|
          if identity.comment.scan('id_rsa').length == 1
            rsaFound = true
          end
        end
        if not rsaFound
          # If we are still running, no rsa key was found. Add one
          @env.ui.info "No RSA key found, running ssh-add to add one."
          Kernel.system "ssh-add"
        end
        # Load and call the default SSH command middleware
        sshCommand = Vagrant::Command::SSH.new @app, @env
        sshCommand.execute()
      end
    end
  end
end

Vagrant.commands.register(:ssh) { ZivtechKeyAdder::Middleware }
