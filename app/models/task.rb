# == Schema Information
#
# Table name: tasks
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  interval   :integer          default(3600)
#  pid        :integer
#  scraper    :string(255)      default("SportsScraper")
#  status     :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Task < ActiveRecord::Base
  enum status: { stopped: 0, running: 1 }

  def stop!
    return if stopped?

    begin
      Process.kill(9, pid)
    rescue => exception
      logger.info exception.backtrace
    ensure
      stopped!
    end
  end

  def run!(league_name = 'NBA')
    return if running?

    process = Spawnling.new(method: :fork) do
      running!

      begin
        scraper.constantize.new(league_name).start
      rescue => exception
        logger.info exception.backtrace
      ensure
        stopped!
      end
    end

    update(pid: process.handle)
  end
end
