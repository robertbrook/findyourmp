

# e.g. assert_model_has_many :questions
def assert_model_has_one(association_name)
  eval %Q|it 'should have one #{association_name.to_s}' do
    model = self.class.description.split.first.constantize
    assert_association_exists model, :has_one, association_name
  end|
end

# e.g. assert_model_has_many :questions
def assert_model_has_many(association_name)
  eval %Q|it 'should have many #{association_name.to_s}' do
    model = self.class.description.split.first.constantize
    assert_association_exists model, :has_many, association_name
  end|
end

# e.g. assert_model_belongs_to :answer
def assert_model_belongs_to(association_name)
  eval %Q|it 'should belong to #{association_name.to_s}' do
    model = self.class.description.split.first.constantize
    assert_association_exists model, :belongs_to, association_name, model_with_foreign_key=model
  end|
end

def assert_association_exists model, association_macro, association_name, model_with_foreign_key=nil
  association = model.reflect_on_association(association_name.to_sym)
  assert_not_nil association, "Could not find an association for #{association_name}"
  assert_equal association_macro, association.macro
  model_with_foreign_key = model_with_foreign_key || association.klass
  begin
    association.klass
  rescue Exception => e
    class_name = association.options[:class_name]
    unless class_name
      klass = e.to_s[/uninitialized constant .*::(.+)/, 1]
      raise "Could not find class #{klass} for association #{association_name}, try defining :class_name in the #{association_macro} association declaration."
    else
      unless class_name.is_a? String
        raise "Could not define association #{association_name} because the defined :class_name #{class_name} is not a String"
      end
    end
  end

  assert model_with_foreign_key.column_names.include?(association.primary_key_name), "Could not find foreign key '#{association.primary_key_name}' for the association '#{association_name}' in the table for model '#{model_with_foreign_key}'."
end
