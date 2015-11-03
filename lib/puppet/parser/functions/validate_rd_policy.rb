
# Validates the rundeck ACL policies
# Usage:
# Example:
# Parser
module Puppet::Parser::Functions
  newfunction(:validate_rd_policy, :doc => <<-'ENDHEREDOC') do |args|
    ENDHEREDOC

    require 'puppet/util/rundeck_acl'

    fail Puppet::ParseError, ("validate_rd_policy(): wrong number of arguments (#{args.length}; must be 1)") unless args.length == 1

    args.each do |arg|
      next if arg.is_a?(Array)
      if arg.is_a?(Hash)
        Puppet::Util::RundeckACL.validate_acl(arg)
      else
        fail Puppet::ParseError, ("#{arg.inspect} is not a Hash or Array of hashes.  It looks to be a #{arg.class}")
      end
    end
  end
end
