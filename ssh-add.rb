require 'vagrant'
require 'net/ssh'

module ZivtechKeyAdder
  class Middleware# < Vagrant::Command::SSH
   def initialize(app, env, options = {})
      @app = app
      @env = env
      # @vm  = env[:vm]
      # See that our plugin is being loaded.
      puts 'initialize'
    end

    def new
      puts 'here'
    end

    def execute
      agent = Net::SSH::Authentication::Agent.connect()
      rsaFound = false
      agent.identities().each do |identity|
        if identity.comment.scan('id_rsa').length == 1
          # env[:ui].info "RSA key found, assuming it is safe for use."
          rsaFound = true
        end
      end
      # If we are still running, no rsa key was found. Add one
      # env[:ui].info "No RSA key found, running ssh-add to add one."
      if not rsaFound
        Kernel.system "ssh-add"
      end
      sshCommand = Vagrant::Command::SSH.new @app, @env
      sshCommand.execute()
    end
  end
end

# ssh_mw = Vagrant::Action::Builder.new do
#   use ZivtechKeyAdder::Middleware
#   # use Vagrant::Command::SSH
# end

app = Vagrant::Action::Builder.new do
  use ZivtechKeyAdder::Middleware
  # use Vagrant::Command::SSH
end
Vagrant.commands.register(:ssh2) { Vagrant::Command::SSH }

Vagrant.commands.register(:ssh) { ZivtechKeyAdder::Middleware }
# Vagrant::Action.run(app)

# Vagrant.commands.register :ssh, app
# Vagrant.commands.register(:ssh) {
#   ZivtechKeyAdder::Middleware
#   Vagrant::Command::SSH
# }

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
