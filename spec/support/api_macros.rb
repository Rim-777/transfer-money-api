module ApiMacros
  extend self

  def code_400_message_base(key, message)
    {
      errors: [
        {
          detail:
            {
              data: {
                attributes: {
                  key => [message]
                }
              }
            }
        }
      ]
    }
  end
end
