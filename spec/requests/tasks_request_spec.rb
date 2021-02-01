require 'rails_helper'

RSpec.describe 'Tasks', type: :request do
  let!(:tasks) { create_list(:task, 10) }
  let(:task_id) { tasks.first.id }

  describe 'GET /tasks' do
    before { get '/tasks' }

    it 'returns all tasks' do
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end
  end

  describe 'GET /tasks/:id' do
    before { get "/tasks/#{task_id}" }

    context 'when task exists' do
      it 'returns status (200) and task' do
        expect(response).to have_http_status(200)
        expect(json).not_to be_empty
        expect(json['id']).to eq(task_id)
      end
    end

    context 'when task does not exist' do
      let(:task_id) { tasks.last.id + 1_000 }

      it 'returns status (200) and nil' do
        expect(response).to have_http_status(200)
        expect(json).to be_nil
      end
    end
  end

  describe 'POST /tasks' do
    let(:valid_params) { { description: 'Task valid test' } }

    context 'when post is valid' do
      it 'creates a task and returns status (201)' do
        post '/tasks', params: valid_params

        expect(response).to have_http_status(201)
        expect(json['description']).to eq('Task valid test')
        expect(json['position'] > tasks.last.position).to be_truthy
      end
    end

    context 'when post is invalid' do
      it 'returns status (422) and a failure message' do
        post '/tasks', params: { description: '' }

        expect(response).to have_http_status(422)
        expect(json['message']).to eq("Validation failed: Description can't be blank")
      end
    end
  end

  describe 'PUT /tasks/:id' do
    context 'when update with valid params' do
      it 'returns status (204) and the task updated' do
        put "/tasks/#{task_id}", params: { description: 'Task Test Updated' }

        expect(response).to have_http_status(204)
        expect(Task.find_by(id: task_id).description).to eq('Task Test Updated')
      end
    end

    context 'when update with invalid params' do
      it 'returns status (422) and an error message' do
        put "/tasks/#{task_id}", params: { description: '' }

        expect(response).to have_http_status(422)
        expect(json['message']).to eq("Validation failed: Description can't be blank")
      end
    end

    context 'when task does not exist' do
      let(:task_id) { tasks.last.id + 1_000 }

      it 'returns status (204) and nil' do
        put "/tasks/#{task_id}", params: { description: 'Task Test Updated' }

        expect(response).to have_http_status(204)
        expect(Task.find_by(id: task_id)).to be_nil
      end
    end
  end

  describe 'DELETE /tasks/:id' do
    before { delete "/tasks/#{task_id}" }

    it 'returns status 204' do
      expect(response).to have_http_status(204)
    end
  end

  describe 'PATCH /tasks/:id/change_position' do
    let(:last_task) { Task.last }

    it 'returns status 202 and the task position' do
      expect(last_task.position).to eq(10)
      expect(Task.find_by(id: task_id).position).to eq(1)

      patch "/tasks/#{task_id}/change_position", params: { position: last_task.position }

      last_task.reload
      expect(response).to have_http_status(202)
      expect(last_task.position).to eq(9)
      expect(Task.find_by(id: task_id).position).to eq(10)
    end
  end
end
