module ApplicationHelper
    def admin_area(&block)
     content_tag(:div, :class => "admin", &block) if admin?
    end

    # returns array of datetime as defined by the cron string between the start_time and the end_time ( or the end of the week if end_time > Time.now.end_of_week )
    def weekly_time_generator(args = {:start_time => Time.now, :end_time => nil, :cron => ''})
        begin
            return [] if args[:cron].blank?

            # get cron as hash
            cron = cron_date args[:cron]

            # get the first value of the cron which is an integer and the pevious index
            # ex: cron = '41 * * * *' - we want to know that it starts every hour (prev index before the number) in the 41-st minute
            for k, v in cron do
                at = v
                break if v.class == 'Fixnum'
                # break in ruby continues the last iteration..
                every = k if v == '*'
            end

            changed_time = start_time = cron_generate_date args[:cron], args[:start_time]
            end_time = args[:end_time]

            # end_time is nil?
            end_time = Time.now.end_of_week if !end_time.respond_to? :year
            # end_time should not be longer than the end of this week
            end_time = end_time > start_time.end_of_week ? start_time.end_of_week : end_time

            all = []
            while changed_time <= end_time
              all << changed_time #changed_time.strftime("%d.%m.%Y %H:%M")
              changed_time += 1.send(every)
            end

            all

        rescue => ex
          send_mail "#{ex.class}: #{ex.message}. args: #{args}"  
        end

    end

    def send_mail(subject, message = '')
        puts subject
    end

    # run the url and record the result to db
    require 'open-uri'
    def run_task(task_id)
        task = Task.find(task_id)
        if !task.blank?
            # puts task.command
            job = open(task.command).read
            job = JSON.parse(job)
            puts job

        else 
            send_mail "Error finding taks #{task_id} in the database"
        end

    end

    # receive text and return hash
    def cron_date(cron)
        raise "empty string" if cron.blank?
        cron = cron.squeeze(' ').split(' ').map { |s| if s.is_number? then s.to_i else s end }
        raise "invalid element count" if cron.size != 5

        cron_date = {year:cron[4], month:cron[3], day:cron[2], hour:cron[1], minute:cron[0]}
        cron_date
    end

    # compare cron with date
    def cron_compare(cron, date)
        begin
            raise "Incorrect date" if !date.respond_to? :year

            cron = cron_date cron

            # we are comparing cron to the current date so:
            # if v == * then v = date.k
            for k,v in cron do
                puts "date.#{k}"
                cron[k] = eval("date.#{k}") if v.class == String
            end
           
            # convert cron in date
            cron = Time.local(cron[:year], cron[:month], cron[:day], cron[:hour], cron[:minute])
            # remove the seconds because we don't have seconds in cron
            date = Time.local(date.year, date.month, date.day, date.hour, date.minute)
            # puts cron, date
            return cron <=> date
        rescue => ex
          send_mail "#{ex.class}: #{ex.message}. cron: #{cron}, date: #{date}"  
        end  
    end

    # generate the next cron date after the given date
    # if date < Time.now.beginning_of_week then date = Time.now
    def cron_generate_date(cron, date)
        begin
            date = Time.now if !date.respond_to? :year

            # if date < Time.now.beginning_of_week then date = Time.now
            date = Time.now if date < Time.now.beginning_of_week
            
            cron = cron_date cron

            #get the key of the last *
            every = cron.select{ |k,v| v == '*' }.keys.last

            # we are comparing cron to the current date so:
            # if v == * then v = date.k
            for k,v in cron do
                #puts "date.#{k}"
                cron[k] = eval("date.#{k}") if v.class == String
            end
           
            # convert cron in date
            cron = Time.local(cron[:year], cron[:month], cron[:day], cron[:hour], cron[:minute])

            # if generated date is < date then increment it by 1 on the first *
            # i.e. cron = '41 18 * * *' and date = '2012-03-15 19:37'.
            # generated date will be 2012-03-15 18:41 which is past date - we want the next cron date which is 2012-03-16 18:41
            cron += 1.send(every) if cron < date

            return cron
        rescue => ex
          send_mail "#{ex.class}: #{ex.message}. cron: #{cron}, date: #{date}"  
        end
    end

    def tt
        sleep 1.minute
    end

end

# redefine the String class
class String
  def is_number?
    true if Float(self) rescue false
  end
end

# redefine the Time class
class Time
  def minute
    self.min
  end
end

# include ApplicationHelper
# cron = '41 * * * *'
# date = Time.parse '2012-02-11 09:05:00'
# puts "date #{date}"
# puts ApplicationHelper.cron_generate_date cron, date
# puts weekly_time_generator(:start_time => date, :end_time => nil, :cron => cron)
#  date = Time.now
#  puts
#  puts
# puts
# puts ApplicationHelper.cron_compare cron, date
# cron = cron_date cron
# for k,v in cron do
#     print k, v, eval("date.#{k}"), (v <=> eval("date.#{k}"))
#     puts
# end

#ApplicationHelper.run_job 1