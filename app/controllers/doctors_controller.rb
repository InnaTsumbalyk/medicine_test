class DoctorsController < ApplicationController
  def index
    @doctors = Doctor.all
  end

  def show
  end

  def create
    @doctor = Doctor.new(doctor_params)
    if @doctor.save
      respond_to do |format|
        format.json { render json: @doctor }
        format.html { redirect_to :back }
      end
    end
  end

  def update
    @doctor = Doctor.find(params[:id])

    if @doctor.update(doctor_params)
      redirect_to edit_company_registration_path
    else
      format.html { render action: "edit" }
    end
  end

  def edit
    if current_company
      @doctor = Doctor.find(params[:id])
      redirect_to root_path unless current_company.id == @doctor.company.id
    else
      redirect_to root_path
    end
  end

  def login
    if current_doctor
      redirect_to current_doctor
    elsif current_company || current_user
      redirect_to root_path
    end
  end

  def create_session
    @doctor = Doctor.find_by(email: params[:email])
    if @doctor
      if @doctor.authenticate(params[:password])
        session[:doctor_id] = @doctor.id
        flash[:notice]='You successful login'
        redirect_to @doctor
      else
        redirect_to root_path
      end
    else
      redirect_to root_path
    end
  end

  def logout
    reset_session
    redirect_to root_path
  end

  def destroy
    @doctor = Doctor.find(params[:id])
    if current_company && current_company.id == @doctor.company.id
      @doctor.destroy
      respond_to do |format|
        format.html { redirect_to company_doctors_path, notice: 'Doctor was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      format.html { redirect_to company_doctors_path, notice: 'unprocessable_entity' }
    end
  end

  def send_password
    password = params[:password]
    email = params[:email]
    DoctorMailer.new_doctor_notification(email, password).deliver_now
    DoctorMailer.company_notification(email, password, current_company.email).deliver_now

    render layout: false
  end

  private

  def doctor_params
    params.require(:doctor).permit(:name, :second_name, :surname, :password, :email, :category, :specialization, :photo).merge(company_id: current_company.id)
  end
end



