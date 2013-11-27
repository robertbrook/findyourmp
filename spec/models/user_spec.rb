require './spec/spec_helper'

describe User do

  describe 'when asked to create admin user' do

    describe 'and users already exist' do
      before do
        User.should_receive(:count).and_return 2
      end
      it 'should not create an admin user' do
        User.should_not_receive(:create!)
        lambda { User.create_admin_user('pass','test@email.com') }.should raise_error
      end
    end

    describe 'and no users already exist' do
      before do
        User.should_receive(:count).and_return 0
      end
      describe 'and no password is supplied' do
        it 'should not create an admin user' do
          User.should_not_receive(:create!)
          lambda { User.create_admin_user('','test@email.com') }.should raise_error
        end
      end
      describe 'and no email is supplied' do
        it 'should not create an admin user' do
          User.should_not_receive(:create!)
          lambda { User.create_admin_user('pass','') }.should raise_error
        end
      end
      describe 'and a password is supplied' do
        it 'should create an admin user setting the supplied password' do
          email = 'test@email.com'
          password = 'pass'
          User.should_receive(:create!).with(:login=>'admin',:email=>email,:admin=>true,:password=>password,:password_confirmation=>password)
          User.create_admin_user(password,email)
        end
      end
    end
  end

end
