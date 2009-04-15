module UserSessionsHelper

  def rm_errors_div html
    html.gsub('<div class="fieldWithErrors">','').chomp('</div>')
  end
end
