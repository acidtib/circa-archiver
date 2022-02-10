class LookupWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  # LookupWorker.perform_async(scroll: true, scroll_pages: 20)
  def perform()
    payload_users = []
    payload_posts = []

    @driver = driver_init()

    begin
      sleep(20)

      visit_page()
      puts "-"*20

      verify_email()

      get_code()

      enter_code()

      log_in()

      sleep(20)

      scroll_page("end")
      sleep(3)
      3.times do
        sleep(1)
        scroll_page("top")
      end

      # grab ul with posts
      wait = Selenium::WebDriver::Wait.new(timeout: 35)
      wait.until { @driver.find_element(:xpath, '/html/body/div/div/div/div/div[2]/div/div[2]/main/div[3]/ul') }

      # click More on post
      @driver.find_elements(:xpath, './/a[contains(., "More")]').each do |r|
        r.click
        sleep(0.5)
      end

      sleep(1)

      # click More Replies on post
      @driver.find_elements(:xpath, './/a[contains(., "More Replies")]').each do |r|
        r.click
        sleep(0.5)
      end

      doc = @driver.find_element(:xpath, '/html/body/div/div/div/div/div[2]/div/div[2]/main/div[3]/ul').attribute("outerHTML")
      html = Nokogiri::HTML5.parse(doc, nil, 'UTF-8')

      html.xpath('//div/li').each do |li|
        post_data = {user: {}, images: [], replies: []}
        
        user_node = li.xpath("div/div[1]")
        post_node = li.xpath("div/div[2]")

        post_data[:user][:name] = user_node.xpath("div[2]/span[1]/p").text.strip
        post_data[:user][:avatar] = user_node.xpath("div[1]/div/img")[0]["src"]

        payload_users << {name: post_data[:user][:name], avatar: post_data[:user][:avatar]}

        post_data[:date] = user_node.xpath("div[2]/span[2]/time").text
        post_data[:epoch] = user_node.xpath("div[2]/span[2]/time")[0]["datetime"].to_s.strip

        post_data[:content_type] = post_node.xpath("div/div/div/div[1]/div[1]/div/div")[0]["title"]
        post_data[:title] = post_node.xpath("div/div/div/div[1]/div[2]/h4[1]").text.strip
        post_data[:sub_title] = post_node.xpath("div/div/div/div[1]/div[2]/h4[2]").text.strip rescue nil
        post_data[:content] = post_node.xpath("div/div/div/div[1]/div[2]/p").text.gsub("  Hide", "")

        # post replies
        post_node.xpath("div/div/div/div[2]/div/div[2]/ul/li").each do |lli|
          ravatar = lli.xpath("div/div[1]/div/img")[0]["src"]
          rname = lli.xpath("div/div[2]/p[1]").text.strip
          rreply = lli.xpath("div/div[2]/p[2]").text          

          # check if reply is myself
          if lli.xpath("div/div[3]").to_s.include? "Remove"
            rdate = lli.xpath("div/div[4]/p/time").text
            repoch = lli.xpath("div/div[4]/p/time")[0]["datetime"].to_s.strip
          else
            rdate = lli.xpath("div/div[3]/p/time").text
            repoch = lli.xpath("div/div[3]/p/time")[0]["datetime"].to_s.strip
          end

          payload_users << {name: rname, avatar: ravatar}

          post_data[:replies] << {name: rname, avatar: ravatar, reply: rreply, date: rdate, epoch: repoch}
        end

        post_images = post_node.xpath("div/div/div/div[1]/div[3]/div")

        if post_images.to_s.length != 0
          img_element = @driver.find_element(:css, "img[src='#{post_images.xpath("div/img")[0]["src"]}']")
          wait = Selenium::WebDriver::Wait.new(timeout: 35)
          wait.until { img_element }

          sleep(5)
          
          # scroll to post image
          @driver.execute_script("arguments[0].scrollIntoView();", img_element)

          # open gallery modal
          wait = Selenium::WebDriver::Wait.new(timeout: 35)
          wait.until { img_element.find_element(:xpath, "../..") }
          img_element.find_element(:xpath, "../..").click

          @driver.find_elements(:class, "image-gallery-image").each do |i|
            s_i = i.find_element(:css, "img").attribute("src")
            next if s_i.include?("c_thumb")
            post_data[:images] << s_i
          end
          
          sleep(5)
          # close the modal
          wait = Selenium::WebDriver::Wait.new(timeout: 35)
          wait.until { @driver.find_element(:xpath, "/html/body/div[2]/div[2]/div/div[1]/h2/div/div[2]/div/button") }
          @driver.find_element(:xpath, "/html/body/div[2]/div[2]/div/div[1]/h2/div/div[2]/div/button").click
        end

        payload_posts << post_data
      end

      sleep(10)
    rescue => exception
      pp exception
    ensure
      shut_it_down()
    end

    payload_users = payload_users.uniq!{|h| h[:name]}
    
    payload_users.each do |u|
      check_user = User.find_by_name(u[:name])
      unless check_user
        check_user = User.create!(name: u[:name], avatar: u[:avatar])
      end
    end

    payload_posts.each do |p|
      InsertPostWorker.perform_in(3.hours, p)
    end
  end

  def selenium_options
    options = Selenium::WebDriver::Chrome::Options.new
    # options.add_argument('--headless')
    # options.add_argument('--log-level=3')
    options.add_argument('--ignore-certificate-errors')
    options.add_argument('--disable-translate')
    options
  end

  def selenium_capabilities_chrome
    Selenium::WebDriver::Remote::Capabilities.chrome
  end

  def driver_init
    caps = [
      selenium_options,
      selenium_capabilities_chrome,
    ]
    
    Selenium::WebDriver.for(:remote, :url => 'http://selenium-hub:4444/wd/hub', :capabilities => caps)
  end

  def shut_it_down()
    @driver.quit
    puts "-"*20
  end

  def visit_page()
    @driver.navigate.to "https://auth.equityapartments.com/Account/LetsGetStarted?returnUrl=%2Fconnect%2Fauthorize%2Fcallback%3Fclient_id%3Dr2p2web%26redirect_uri%3Dhttps%253A%252F%252Fmy.equityapartments.com%252Fcallback%26response_type%3Dtoken%2520id_token%26scope%3Dopenid%2520profile%2520email%2520papi.resident_access%26state%3D1e2caeadc4ff4071b814599efd5865b2%26nonce%3D247f9f0a8e5247b5803b107fa33b4505"
  
    wait = Selenium::WebDriver::Wait.new(timeout: 35)
    wait.until { @driver.find_element(name: "Username") }
  end

  def scroll_page(to)
    if to == 'end'
      @driver.execute_script('window.scrollTo(0,Math.max(document.documentElement.scrollHeight,document.body.scrollHeight,document.documentElement.clientHeight));')
    elsif to == 'top'
      @driver.execute_script('window.scrollTo(Math.max(document.documentElement.scrollHeight,document.body.scrollHeight,document.documentElement.clientHeight),0);')
    else
      raise "Exception : Invalid Direction (only scroll \"top\" or \"end\")"
    end
  end

  def verify_email()
    set_username = @driver.find_element(name: 'Username')
    set_username.clear()
    set_username.send_keys(ENV["CIRCA_USERNAME"])
  
    @driver.find_element(class: 'btn-login').click
  end

  def get_code()
    wait = Selenium::WebDriver::Wait.new(timeout: 35)
    wait.until { @driver.find_element(name: "UsePhone") }
  
    @driver.find_element(:css, "[name='UsePhone'][value='False']").click
  
    @driver.find_element(class: 'btn-login').click
  end

  def fetch_code()
    sleep(25)

    Setting.first.equity_code
  end

  def enter_code()
    wait = Selenium::WebDriver::Wait.new(timeout: 35)
    wait.until { @driver.find_element(name: "TwoFactorCode") }
  
    new_access_code = fetch_code()
  
    set_code = @driver.find_element(name: 'TwoFactorCode')
    set_code.clear()
    set_code.send_keys(new_access_code)
  
    # @driver.find_element(class: 'btn-login').click
    @driver.find_element(css: '.form-group button.btn-primary').click
  end

  def log_in()
    wait = Selenium::WebDriver::Wait.new(timeout: 35)
    wait.until { @driver.find_element(name: "Username") }
  
    set_username = @driver.find_element(name: 'Username')
    set_username.clear()
    set_username.send_keys(ENV["CIRCA_USERNAME"])
  
    set_password = @driver.find_element(name: 'Password')
    set_password.clear()
    set_password.send_keys(ENV["CIRCA_PASSWORD"])
  
    @driver.find_element(class: 'btn-login').click
  end
end