#!/usr/bin/env ruby
# Id$ nonnax 2021-10-02 15:13:19 +0800
# mdview - markdown viewer for jlog.rb
# uses: bat for markdown output
require 'json'
json_hash=ARGV.first.split("\t", 2).last
md_text= JSON.parse(json_hash, symbolize_names: true)[:text]
cmd="echo '#{md_text}' | bat -pp -l markdown --color=always"
puts IO.popen(cmd, &:read)
