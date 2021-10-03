#!/usr/bin/env ruby
# frozen_string_literal: true
# jlog.rb
#	a CLI journal logger
# Id$ nonnax 2021-10-01 13:18:59 +0800
require 'fzf'
require 'yaml'
require_relative 'editor'
require_relative 'hashfile'

HOME_PATH=File.expand_path('~')

puts "#{$0} 1"
puts "or"
puts "cat <File> | #{$0} "

command = ARGV.empty? ? '' : ARGV

if not STDIN.tty? and not STDIN.closed?
	command = $stdin.readlines.join
else
	p "no input"
end

DATA_FILE = [Time.now.strftime('%Y-%m'), 'json'].join('.')

$default_tags = %w[
  note
  ruby
  ffmpeg
  vault
]

$config = {
  path: HOME_PATH,
  tags: $default_tags
}

def load_config
	# edit .jlog.yaml to update path and add tags
  p config_file = File.expand_path(
    File.join(
      HOME_PATH,
      '.jlog.yaml'
    )
  )

  if File.exist?(config_file)
    $config = YAML.load(
    						File.read(config_file)
    					)
    $default_tags = $config[:tags]
  else
  	
    File.open(config_file, 'w') { |f| f.write $config.to_yaml }
  end
end

# --------------------------
load_config

DATA_PATH = File.expand_path(
					File.join(
							$config[:path],
							DATA_FILE
							)
					)

data = { entries: [] }
data.load(DATA_PATH) if File.exist?(DATA_PATH)

def edit(data)
	# fzf expects strings
  data[:tags] = data[:tags].join(',')
	
  loop do
    k, v = data
           .fzf_map
           .first
    break unless k

    case k
    when :text, :timestamp
      v = IO
          .editor(data[k])
          .chomp
    else
      choices = $default_tags.uniq
      next if (v_new = choices.fzf).empty?
      v = v_new
          .uniq
          .join(',')
    end
    data[k] = v
  end
  #restore array post-fzf
  data[:tags] = data[:tags].split(/,/) 
  data.merge!(timestamp: Time.now.strftime('%Y-%m-%dT%X'))

  yield data if block_given?
  data
end

def data.list_choices
  self[:entries]
    .fzf_with_index(cmd: %(fzf --preview-window=top --preview='yamlview.rb {} | bat -pp -l markdown' --ansi ))
    .first
end

def data.add(path, text="")
  entry = {
    text: text.chomp,
    tags: %w[note]
  }
  new_row = text.strip=="" ? edit(entry) : entry
  return if new_row[:text].strip == ''

  (self[:entries] ||= []) << new_row
  save(path)
  puts new_row.to_yaml
end

case 
when Array===command
  loop do
    index, v = data.list_choices
    break unless index

    row = data[:entries][index]
    data[:entries][index] = edit(row)
    data.save(DATA_PATH)
  end
else
	  data.add(DATA_PATH, command)
end
