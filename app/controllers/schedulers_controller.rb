class SchedulersController < ApplicationController
  # GET /schedulers
  # GET /schedulers.json
  def index
    # load schedulers only for this task
    if params[:task_id] then
      @schedulers = Scheduler.where("task_id=#{params[:task_id].to_i}").order('id DESC')
      @task_name = ' for ' + Task.find(params[:task_id]).name
    else
      @schedulers = Scheduler.order('id DESC')
      @task_name = ''
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @schedulers }
    end
  end

  # GET /schedulers/1
  # GET /schedulers/1.json
  def show
    @scheduler = Scheduler.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @scheduler }
    end
  end

  # GET /schedulers/new
  # GET /schedulers/new.json
  def new
    @scheduler = Scheduler.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @scheduler }
    end
  end

  # GET /schedulers/1/edit
  def edit
    @scheduler = Scheduler.find(params[:id])
  end

  # POST /schedulers
  # POST /schedulers.json
  def create
    @scheduler = Scheduler.new(params[:scheduler])

    respond_to do |format|
      if @scheduler.save
        format.html { redirect_to @scheduler, notice: 'Scheduler was successfully created.' }
        format.json { render json: @scheduler, status: :created, location: @scheduler }
      else
        format.html { render action: "new" }
        format.json { render json: @scheduler.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /schedulers/1
  # PUT /schedulers/1.json
  def update
    @scheduler = Scheduler.find(params[:id])

    respond_to do |format|
      if @scheduler.update_attributes(params[:scheduler])
        format.html { redirect_to @scheduler, notice: 'Scheduler was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @scheduler.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schedulers/1
  # DELETE /schedulers/1.json
  def destroy
    @scheduler = Scheduler.find(params[:id])
    @scheduler.destroy

    respond_to do |format|
      format.html { redirect_to schedulers_url }
      format.json { head :no_content }
    end
  end
end
