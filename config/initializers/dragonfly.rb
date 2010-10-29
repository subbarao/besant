require 'dragonfly'

app = Dragonfly[:images]
app.configure_with(:rmagick)
app.configure_with(:rails)
app.define_macro(ActiveRecord::Base, :image_accessor)
