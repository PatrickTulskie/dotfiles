#!/usr/bin/env ruby
require 'open3'

cmd = 'git log --shortstat --pretty=format:"%an"'
stdout_str, stderr_str, status = Open3.capture3(cmd)

unless status.success?
  $stderr.puts "Failed to run git log command: #{stderr_str}"
  exit 1
end

lines = stdout_str.lines.map(&:rstrip)

authors_additions = Hash.new(0)
authors_deletions = Hash.new(0)

current_author = nil
added = 0
deleted = 0

lines.each do |line|
  if line.strip.empty?
    # Blank line: commit ends, record totals
    if current_author
      authors_additions[current_author] += added
      authors_deletions[current_author] += deleted
    end
    # Reset counters
    added = 0
    deleted = 0
  elsif line.start_with?(' ')
    # Shortstat line: parse out insertions and deletions
    # Example: " 1 file changed, 2 insertions(+), 3 deletions(-)"
    # Insertions:
    if line =~ /(\d+) insertions?\(\+\)/
      added += $1.to_i
    end
    # Deletions:
    if line =~ /(\d+) deletions?\(-\)/
      deleted += $1.to_i
    end
  else
    # Author line:
    current_author = line
    # If there's a commit without any shortstat line following (e.g., empty commit),
    # the totals (0,0) will be recorded at the next blank line.
  end
end

# If the log doesn't end with a blank line, finalize the last commit here
if current_author && (added > 0 || deleted > 0)
  authors_additions[current_author] += added
  authors_deletions[current_author] += deleted
end

# Sort by deletions descending
sorted = authors_deletions.keys.sort_by { |a| -authors_deletions[a] }

# Determine widths for formatting
author_col_width = ["Author", *sorted].map(&:length).max
del_col_width = ["Deletions", *sorted.map { |a| authors_deletions[a].to_s }].map(&:length).max
add_col_width = ["Additions", *sorted.map { |a| authors_additions[a].to_s }].map(&:length).max

puts "Generating contribution report..."
puts "%-#{author_col_width}s  %#{del_col_width}s  %#{add_col_width}s" % ["Author", "Deletions", "Additions"]
sorted.each do |a|
  puts "%-#{author_col_width}s  %#{del_col_width}d  %#{add_col_width}d" % [a, authors_deletions[a], authors_additions[a]]
end
