class Sessions::Event::ChatStatusAgent < Sessions::Event::ChatBase

  def run
    return super if super

    # check if user has permissions
    return if !role_permission_check('Agent', 'chat')

    # renew timestamps
    state = Chat::Agent.state(@session['id'])
    Chat::Agent.state(@session['id'], state)

    # update recipients of existing sessions
    Chat::Session.where(state: 'running', user_id: @session['id']).order('created_at ASC').each {|chat_session|
      chat_session.add_recipient(@client_id, true)
    }
    {
      event: 'chat_status_agent',
      data: Chat.agent_state_with_sessions(@session['id']),
    }
  end

end
