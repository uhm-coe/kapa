# Liquid filters for Kapa::Content templates. Variables reach a body already HTML-escaped
# (Kapa::Content#to_html), so escape (and its alias h) leave escaped text alone instead of escaping
# it twice, and templates written with | escape keep working.
module Kapa::LiquidFilters
  def escape(input)
    escape_once(input)
  end

  def h(input)
    escape_once(input)
  end
end
