class TasksController < ApplicationController
  before_action :set_task, only: %i[show update destroy change_position]

  def index
    @tasks = Task.all.order(:position)
    json_response(@tasks)
  end

  # GET /tasks/:id
  def show
    json_response(@task)
  end

  # POST /tasks
  def create
    @task = Task.create!(params_task)
    json_response(@task, :created)
  end

  # PUT /tasks/:id
  def update
    @task&.update!(params_task)
    json_response(@task, :no_content)
  end

  # DELETE /tasks/:id
  def destroy
    @task.destroy
    head :no_content
  end

  # PATCH /tasks/:id/change_position
  def change_position
    @task.insert_at(params_task[:position].to_i)
    head :accepted
  end

  private

  def params_task
    params.permit(:description, :position, :done)
  end

  def set_task
    @task = Task.find_by(id: params[:id])
  end
end
