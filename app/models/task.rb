# encoding: utf-8

class Task < ActiveRecord::Base
    belongs_to :project
    has_many :logs
    has_many :schedulers

    StandardTimeout = 20

    # @cron_el = '(\*|\d+|\d+,\d+|\d+,\d+,\d+)'
    @cron_el = '(\*|\d{1}|\d{2})'
    validates :name, :project_id, :cron_time, :command, :presence => true
    validates :cron_time, :format => { :with => /#{@cron_el} #{@cron_el} #{@cron_el} #{@cron_el} #{@cron_el}/, 
        :message => "Invalid cron format" }

    def start_at_safe
        !self.start_at.blank? ? self.start_at.strftime("%d.%m.%Y %H:%M") : ''
    end

    def end_at_safe
        !self.end_at.blank? ? self.end_at.strftime("%d.%m.%Y %H:%M") : ''
    end

    def timeout_safe
        !self.timeout.blank? ? self.timeout.strftime("%H:%M") : ''
    end

    # schedule the current task for execution
    include ApplicationHelper
    def schedule

      # get schedule times until the end of the week if any
      schedule_dates = weekly_time_generator(:start_time => self.start_at, :end_time => self.end_at, :cron => self.cron_time)

      # if blank then there is nothing to update
      return false if schedule_dates.empty?

      # prepare for insertion
      dates = schedule_dates.map{ |date| {start_at:date, task_id:self.id, is_started:0} }

      # delete the remaining schedulers for this self
      self.schedulers.where('start_at >= NOW() AND is_started=0').destroy_all

      # add the new scheduling only if self is active
      self.schedulers.create(dates) if self.is_active and self.project.is_active

    end

    # run the url and record the result to db
    require 'open-uri'
    require 'time'
    require 'timeout'
    def run
        begin
            # if no timeout is specified uset the standard 8 hours timeout
            custom_timeout = Task::StandardTimeout
            if self.timeout.respond_to? :year then
              # convert H:m in seconds i.e. 2:10 in 2.hours + 10.minutes
              custom_timeout =  self.timeout.hour.hours + self.timeout.min.minutes
            end
            
            log = self.logs.new
            
            Timeout::timeout(custom_timeout) do
            
                if !self.command.empty? then
                    # start the task
                    job = open(self.command).read
                    log.result = job

                    # mark the log as error
                    log.is_error = true if job =~ /error/i
                    
                else 
                    send_mail "Error running taks #{self.id} - the command is empty"
                end
            end

        rescue Timeout::Error
          log.is_timeout = true
          job ||= "A timeout occured after #{custom_timeout} seconds"
          log.result ||= job
          send_mail "Error running taks #{self.id} with result: '#{job}'"

        rescue Exception => e
          # make sure that job is defined
          job ||= 'no result'
          msg = "Error running taks #{self.id} with result: '#{job}'. Exception: #{e.class}: #{e.message}."
          log ||= self.logs.new
          log.result = msg
          log.is_error = true
          send_mail msg

        ensure
          job ||= 'no result'
          log ||= self.logs.new
          send_mail "Error saving running taks #{task.id} with result: '#{job}'" if !log.save
        end

    end

end