# == Schema Information
#
# Table name: tasks
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  interval   :integer          default(3600)
#  pid        :integer
#  scraper    :string(255)      default("SportsScraper")
#  status     :string(255)      default("0")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Task < ActiveRecord::Base
  enum status: { brand_new: 0, running: 1, done: 2, stopped: 3, failed: 4 }

  def running?
    return false unless pid
    begin
      Process.kill(0, pid)
      return true
    rescue
      return false
    end
  end

  def stop!
    if running?
      begin
        Process.kill 9, pid
        stopped!
      rescue Exception => ex
        # @todo what goes here?
      end
    elsif running?
      begin
        Process.kill 9, pid
        stopped!
      rescue Exception => ex
        # @todo what goes here?
      end
    elsif running?
      stopped!
      save
    else
      raise "Already stopped"
    end
  end

  def run!
    return if running?

    running!

    # if name == 'Yahoo Sports (Ongoing)'
    #   cmd = "ruby #{PATH_ONGOING} -t #{id} -i #{interval}"
    # else
    #   cmd = "ruby #{PATH_OVER} -t #{id} -i #{interval}"
    # end

    # Detach process and get its PID
    process = IO.popen(cmd)
    Process.detach(process.pid)
    update(pid: process.pid)
  end
end
