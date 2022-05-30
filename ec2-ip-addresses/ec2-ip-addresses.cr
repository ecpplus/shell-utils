require "process"
require "json"

aws_profile = nil
aws_profile = ARGV[0] if 0 < ARGV.size

stdout = IO::Memory.new
stderr = IO::Memory.new

aws_command_args = %w|ec2 describe-instances --filters --region ap-northeast-1|
aws_command_args += ["--profile", aws_profile] if aws_profile

status = Process.run(
  "aws",
  aws_command_args,
  output: stdout,
  error: stderr,
)

unless status.success?
  puts "Failed"
  puts stderr
  exit 1
end

result = JSON.parse(stdout.to_s)
instances = result["Reservations"].as_a.flat_map do |reservation|
  reservation["Instances"].as_a.map do |instance|
    name = ""
    if instance["Tags"]? != nil
      name_tag = instance["Tags"].as_a.find { |tag| tag["Key"]? == "Name" }
      name = name_tag.not_nil!.dig("Value").as_s
    end

    public_ip_addr = instance["PublicIpAddress"]?
    private_ip_addr = instance["PrivateIpAddress"]?
    if name_tag != nil
      {
        name:              name,
        public_ip_address: public_ip_addr ? public_ip_addr.not_nil!.as_s : "",
        private_ip_address: private_ip_addr ? private_ip_addr.not_nil!.as_s : "",
      }
    end
  end
end.select { |h| h != nil }.sort_by { |h| h.not_nil![:name] }

max_name_length = instances.max_of { |h| h.not_nil!.[:name].not_nil!.size }
max_public_ip_length = instances.max_of { |h| h.not_nil!.[:public_ip_address].not_nil!.size }
max_private_ip_length = instances.max_of { |h| h.not_nil!.[:public_ip_address].not_nil!.size }

instances.each do |h|
  puts "%#{max_name_length}s   %#{max_public_ip_length}s   %#{max_private_ip_length}s" % [h.not_nil![:name], h.not_nil![:public_ip_address], h.not_nil![:private_ip_address]]
end
