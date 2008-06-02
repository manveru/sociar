Configuration.for 'sociar' do
  ramaze do
    host '0.0.0.0'
    port 80
  end

  sequel do
    db 'sqlite:///blog.db'
  end
end
