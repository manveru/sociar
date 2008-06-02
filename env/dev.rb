Configuration.for 'sociar' do
  sequel do
    db 'sqlite:/'
    logger Ramaze::Log
  end
end
