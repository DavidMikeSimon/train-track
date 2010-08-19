task :git_status do
  puts `git status`;
  heroku_diff = `git diff --shortstat HEAD..heroku/master`;
  if heroku_diff.size > 0
    puts "Heroku diff: #{heroku_diff}"
  end
end
