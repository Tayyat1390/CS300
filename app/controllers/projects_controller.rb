class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]
  before_action :authenticate_project_user!, only: [:create, :update, :destroy]
  before_action :is_authorised, only: [:update, :destroy]

  # GET /projects or /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1 or /projects/1.json
  def show
    @project = Project.find(params[:id]) 
    @project.last_viewed = Time.now unless current_project_user
    @project.clicks += 1 unless current_project_user
    @project.save
  end

  def image
    @project = Project.find(params[:id]) 
    send_data(@project.img, :type => 'image/png', :disposition => "inline")
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects or /projects.json
  def create
    @project = Project.new(project_params)
    @project.user = current_project_user.email
    @project.clicks = 0
    @project.last_viewed = Time.now

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: "Project was successfully created." }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    @project.last_viewed = Time.now unless current_project_user
    @project.clicks += 1 unless current_project_user

    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: "Project was successfully updated." }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    @project.destroy!
    respond_to do |format|
      format.html { redirect_to projects_url, notice: "Project was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:name, :uri, :img, :data) if params[:project]
    end

    def is_authorised
      redirect_to root_path, alert: "You don't have permission to moify this asset." unless current_project_user.email == @project.user
    end
    
end
