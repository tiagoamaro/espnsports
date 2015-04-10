# == Schema Information
#
# Table name: leagues
#
#  LeagueID   :integer          not null, primary key
#  LeagueName :string(50)
#  SportID    :integer
#  SportName  :string(50)
#

class League < ActiveRecord::Base
  self.primary_key = 'LeagueID'
end
