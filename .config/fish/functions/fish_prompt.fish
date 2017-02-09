function fish_prompt
  if git_is_repo
    printf '%s %s %s %s %s ' (set_color blue)(echo '⋊>') (set_color bryellow)(prompt_pwd) (set_color white)(echo 'on') (set_color green)(git_is_branch) (set_color white)(echo '○')(set_color white)
  else
    printf '%s %s ' (set_color blue)(echo '⋊>') (set_color bryellow)(prompt_pwd)(set_color white)
  end
end
