# == Schema Information
#
# Table name: tasks
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  interval   :integer          default(3600)
#  pid        :integer
#  progress   :string(255)
#  status     :string(255)      default("0")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Task < ActiveRecord::Base
  enum status: { brand_new: 0, running: 1, done: 2, stopped: 3, failed: 4 }

  def update_status!
    if !self.running?
      self.update_attributes(status: STOPPED, progress: '')
    end
  end

  def running?
    return false unless self.pid
    begin
      Process.kill(0, self.pid.to_i)
      return true
    rescue
      return false
    end
  end

  def stop!
    if self.running?
      begin
        Process.kill 9, self.pid.to_i
        self.status = STOPPED
        self.progress = 'Terminated'
        self.save
      rescue Exception => ex
        # @todo what goes here?
      end
    elsif self.running? && self.status != RUNNING
      begin
        Process.kill 9, self.pid.to_i
        self.status = STOPPED
        self.save
      rescue Exception => ex
        # @todo what goes here?
      end
    elsif self.status = RUNNING
      self.status = STOPPED
      self.save
    else
      raise "Already stopped"
    end
  end

  private
  def run!
    if self.running?
      # already running
    else
      self.status = RUNNING
      self.progress = 'Starting...'
      self.save

      if self.name == 'Yahoo Sports (Ongoing)'
        cmd = "ruby #{PATH_ONGOING} -t #{self.id} -i #{self.interval}"
      else
        cmd = "ruby #{PATH_OVER} -t #{self.id} -i #{self.interval}"
      end

      p cmd

      process = IO.popen(cmd)
      Process.detach(process.pid)
      self.pid = process.pid
      self.save
    end
  end
end
