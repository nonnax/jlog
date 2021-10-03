#!/usr/bin/env ruby
# Id$ nonnax 2021-10-02 15:13:19 +0800
require 'json'
inp=ARGV.first.split("\t", 2).last
puts JSON.parse(inp, symbolize_names: true)[:text]
