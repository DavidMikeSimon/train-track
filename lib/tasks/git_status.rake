task :heroku_diff do
  heroku_diff = `git diff --shortstat HEAD..heroku/master`;
  if heroku_diff.size > 0
    puts "Heroku diff from HEAD: #{heroku_diff}"
  else
    puts "Heroku is at HEAD"
  end
end
