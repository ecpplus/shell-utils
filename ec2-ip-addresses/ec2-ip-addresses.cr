require "process"
require "json"

stdout = IO::Memory.new
stderr = IO::Memory.new

status = Process.run(
  "aws",
  %w|ec2 describe-instances --filters --region ap-northeast-1|,
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

    ip_addr = instance["PublicIpAddress"]?
    if name_tag != nil && ip_addr != nil
      {
        name:              name,
        public_ip_address: ip_addr ? ip_addr.not_nil!.as_s : "",
      }
    end
  end
end.select { |h| h != nil }.sort_by { |h| h.not_nil![:name] }

max_name_length = instances.max_of { |h| h.not_nil!.[:name].not_nil!.size }

instances.each do |h|
  puts "%#{max_name_length}s    %s" % [h.not_nil![:name], h.not_nil![:public_ip_address]]
end
