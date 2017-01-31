function fish_prompt
  printf '%s %s ' (set_color blue)(echo '⋊>') (set_color bryellow)(prompt_pwd)
end
