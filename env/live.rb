Configuration.for 'sociar' do
  ramaze do
    host '0.0.0.0'
    port 80
  end

  sequel do
    db 'sqlite:///sociar.db'
    logger nil
  end
end
