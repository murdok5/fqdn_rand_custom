require 'digest/md5'

  def deterministic_rand_custom(seed,max)
    if defined?(Random) == 'constant' && Random.class == Class
      Random.new(seed).rand(max).to_s
    else
      srand(seed)
      result = rand(max).to_s
      srand()
      result
    end
  end


Puppet::Parser::Functions::newfunction(:fqdn_rand_custom, :arity => -2, :type => :rvalue, :doc =>
  "Usage: `fqdn_rand_custom(MAX, [SEED])`. MAX is required and must be a positive
  integer; SEED is optional and may be any number or string.

  Generates a random Integer number greater than or equal to 0 and less than MAX,
  combining the `$fqdn` fact and the value of SEED for repeatable randomness.
  (That is, each node will get a different random number from this function, but
  a given node's result will be the same every time unless its hostname changes.)

  This function is usually used for spacing out runs of resource-intensive cron
  tasks that run on many nodes, which could cause a thundering herd or degrade
  other services if they all fire at once. Adding a SEED can be useful when you
  have more than one such task and need several unrelated random numbers per
  node. (For example, `fqdn_rand_custom(30)`, `fqdn_rand_custom(30, 'expensive job 1')`, and
  `fqdn_rand_custom(30, 'expensive job 2')` will produce totally different numbers.)") do |args|
    max = args.shift.to_i
    seed = Digest::MD5.hexdigest([self['::fqdn'],args].join(':')).hex
    deterministic_rand_custom(seed,max)
end
