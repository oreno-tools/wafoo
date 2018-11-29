class String
  def to_ok_message
    "\e[32m" + self + "\e[0m"
  end

  def to_error_message
    "\e[31m" + self + "\e[0m"
  end

  def to_info_message
    "\e[36m" + self + "\e[0m"
  end
end
