class WebhookController < ApplicationController
  def ping
    access_code = nil

    if params["summary"] && params["summary"].length != 0
      access_code = params["summary"].split("hello@dainelvera.com")[1].split("Please enter")[0].gsub(":", "").strip.to_s
    end

    if access_code.nil? == false
      Setting.first.update(equity_code: access_code)
    end

    render json: {}
  end
end
