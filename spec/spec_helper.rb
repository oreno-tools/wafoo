require 'rspec'
require 'wafoo'

Aws.config.update(stub_responses: true)
# ENV['AWS_PROFILE'] = 'dummy_profile'
ENV['AWS_ACCESS_KEY_ID'] = 'XXXXXXXXXXXXXXXXXXXX'
ENV['AWS_SECRET_ACCESS_KEY'] = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
ENV['AWS_REGION'] = 'us-east-1'
ENV['LOAD_STUB'] = 'true'

def capture(stream)
  begin
    stream = stream.to_s
    eval "$#{stream} = StringIO.new"
    yield
    result = eval("$#{stream}").string
  ensure
    eval("$#{stream} = #{stream.upcase}")
  end
  result
end
