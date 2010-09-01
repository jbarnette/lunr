require "isolate/now"
require "hoe"

Hoe.plugins.delete :rubyforge
Hoe.plugin :doofus, :git, :isolate

Hoe.spec "lunr" do
  developer "John Barnette", "code@jbarnette.com"

  self.extra_rdoc_files = Dir["*.rdoc"]
  self.history_file     = "CHANGELOG.rdoc"
  self.readme_file      = "README.rdoc"
  self.testlib          = :minitest
end
