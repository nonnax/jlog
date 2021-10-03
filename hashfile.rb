#!/usr/bin/env ruby
# frozen_string_literal: true

# module HashFile
# Hash persistence via JSON
# Id$ nonnax 2021-10-01 18:16:10 +0800
require 'json'

module HashFile
  def self.included(obj)
    obj.extend(ClassMethods)
  end

  module ClassMethods
    def open(f, &block)
      hsh = {}
      hsh.load(f)
      hsh.save(&block)
      hsh
    end
  end

  def load(f=nil)
    @jfile ||= f
    File.open(@jfile) do |f|
      replace(JSON.parse(f.read, symbolize_names: true))
    end
  end

  def save(f = nil, mode = 'w+', &block)
    @jfile ||= f
    instance_eval(&block) if block_given?
    File.open(@jfile, mode) do |f|
      f.write JSON.pretty_generate(self)
    end
    self
  end
  alias dump save
  alias open save

	def symbolize_keys
	  inject({}){|result, (key, value)|
	    new_key = String===key ?  key.to_sym : key
	    new_value = Hash===value ? value.symbolize_keys : value
	    result[new_key] = new_value
	    result
	  }
	end  
end

class Hash
  include HashFile
end

if __FILE__ == $PROGRAM_NAME
  h = {
    title: 'hashfile.rb',
    text: 'adds load and save methods to Hash',
    "inner":  {
    	'inny': 'one', 
    	'outy': 'two' 
    }
  }
  p h.symbolize_keys
  
	p h.open('save.json')
  p h.save('save.json')

  hsh=Hash.open('save.json') do
    merge!(another_key: 'what is this')
  end
	p hsh
end
