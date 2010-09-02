unless Gem.available? "isolate"
  abort "Please `gem install isolate` and run rake again."
end

require "isolate/now"
require "hoe"

Hoe.plugins.delete :rubyforge
Hoe.plugin :doofus, :git, :isolate

Hoe.spec "lunr" do
  developer "John Barnette", "code@jbarnette.com"

  require_ruby_version ">= 1.8.7"

  self.extra_rdoc_files = Dir["*.rdoc"]
  self.history_file     = "CHANGELOG.rdoc"
  self.readme_file      = "README.rdoc"
  self.testlib          = :minitest
end
