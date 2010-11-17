require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ScrapperTest < ActiveSupport::TestCase

  THEATER_HTML = '<div class="theater"><div id="theater_11954524651057257122"><div class="name"><a id="link_1_theater_11954524651057257122" href="/movies?near=20170&amp;sort=1&amp;tid=a5e700d514eb1aa2">Regal Countryside 20</a></div><div class="address">45980 Regal Plaza, Sterling, VA<a target="_top" class="fl" href=""></a></div></div><div class="times"><a href="/url?q=http://www.fandango.com/redirect.aspx%3Ftid%3DAADXX%26tmid%3D92475%26date%3D2010-11-17%2B12:40%26a%3D11584%26source%3Dgoogle&amp;sa=X&amp;oi=moviesf&amp;ii=7&amp;usg=AFQjCNGKxS4_LjdvMPARNc3xmL-6m4m4PQ">12:40</a>&nbsp; <a href="/url?q=http://www.fandango.com/redirect.aspx%3Ftid%3DAADXX%26tmid%3D92475%26date%3D2010-11-17%2B15:05%26a%3D11584%26source%3Dgoogle&amp;sa=X&amp;oi=moviesf&amp;ii=7&amp;usg=AFQjCNE2_GWZTZQ4jtPqHAdrrpQZ7ywZRw">3:05</a>&nbsp; <a href="/url?q=http://www.fandango.com/redirect.aspx%3Ftid%3DAADXX%26tmid%3D92475%26date%3D2010-11-17%2B17:30%26a%3D11584%26source%3Dgoogle&amp;sa=X&amp;oi=moviesf&amp;ii=7&amp;usg=AFQjCNH6aGrF3V608QbXZGXbYvNxfsYwmg">5:30</a>&nbsp; <a href="/url?q=http://www.fandango.com/redirect.aspx%3Ftid%3DAADXX%26tmid%3D92475%26date%3D2010-11-17%2B20:00%26a%3D11584%26source%3Dgoogle&amp;sa=X&amp;oi=moviesf&amp;ii=7&amp;usg=AFQjCNHskU0A93YawznyaXzdLBItMg1xZQ">8:00</a>&nbsp; <a href="/url?q=http://www.fandango.com/redirect.aspx%3Ftid%3DAADXX%26tmid%3D92475%26date%3D2010-11-17%2B22:25%26a%3D11584%26source%3Dgoogle&amp;sa=X&amp;oi=moviesf&amp;ii=7&amp;usg=AFQjCNFJoM5ZleqJT2kk-ONDtFh0qFKh4g">10:25pm</a></div></div>'

  context "Scrapper Theater instance" do
    setup do
      @theater = Scrapper::Theater.new(Hpricot(THEATER_HTML))
    end

    should "know the address info" do
      assert_equal "45980 Regal Plaza, Sterling, VA", @theater.address
    end

    should "know the showtimes" do
      assert_equal "12:40  3:05  5:30  8:00  10:25pm", @theater.times
    end

    should "know the theater name" do
      assert_equal "Regal Countryside 20", @theater.name
    end
  end
end
