function fish_prompt
  if test "$fish_key_bindings" = "fish_vi_key_bindings"
    switch $fish_bind_mode
      case default
        set_color white
      case insert
        set_color blue
      case replace-one
        set_color blue
      case visual
        set_color magenta
    end
  else
    set_color blue
  end

  if git_is_repo
    printf "%s %s %s %s %s " (echo "⋊>") (set_color bryellow)(prompt_pwd) (set_color white)(echo "on") (set_color green)(git_is_branch) (set_color white)(echo "○")(set_color white)
  else
    printf "%s %s " (echo "⋊>") (set_color bryellow)(prompt_pwd)(set_color white)
  end
end
