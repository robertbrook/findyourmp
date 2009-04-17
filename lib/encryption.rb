module FindYourMP
  module Encryption      
    def symmetric_file_encryption(cipher, input, output)
      cipher.encrypt
      size = File.size(input)
      blocks = size / 16

      File.open(output,'w') do |enc|
        File.open(input) do |file|
          for i in 1..blocks-1
            block = file.read(16)
            enc << cipher.update(block)
          end

          if size%16 > 0
            pad_size = 16 - size%16
            padding = ""
            padding = padding.ljust(pad_size+1, " ")

            block = file.read() << padding
            enc << cipher.update(block)

            enc << cipher.final
            enc << pad_size.to_s(base=16)
          end
        end
      end
    end

    def symmetric_file_decryption(cipher, input, output)
      cipher.decrypt
      size = File.size(input)
      blocks = size / 16

      if size%16 > 0
        blocks = blocks - 1
      end

      File.open(output,'w') do |dec|
        File.open(input) do |file|        
          for i in 1..blocks
            block = file.read(16)
            dec << cipher.update(block)
          end

          if size%16 >0
            last_bit_crypted = file.read(16)
            last_bit_plain = cipher.update(last_bit_crypted)

            pad_size = file.read().hex
            pad_size+=1
            dec << last_bit_plain[0..-pad_size]
          end
        end
      end
    end

    def asymmetric_encryption(keyfile, plain_text)
      public_key_file = keyfile
      public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))  

      encrypted = public_key.public_encrypt(plain_text)
      encrypted
    end

    def asymmetric_decryption(keyfile, password, encrypted)
      private_key_file = keyfile 
      private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file),password)  

      decrypted = private_key.private_decrypt(encrypted)
      decrypted
    end

    def encrypt_file(input, output, alg, pem_file)
      cipher = OpenSSL::Cipher::Cipher.new(alg)
      cipher.encrypt
      cipher.key = cipher_key = cipher.random_key
      cipher.iv = cipher_iv = cipher.random_iv

      symmetric_file_encryption(cipher, input, output)
      output_extension = File.extname(output)

      key_file = output.gsub(output_extension, "_key.txt")
      File.open(key_file,'w') do |file|
        file << asymmetric_encryption(pem_file, cipher_key)
      end

      iv_file = output.gsub(output_extension, "_iv.txt")
      File.open(iv_file,'w') do |file|
        file << asymmetric_encryption(pem_file, cipher_iv)
      end
    end
    
    def decrypt_file(input, output, alg, password, pem_file)      
      input_extension = File.extname(input)
      key_file = input.gsub(input_extension, "_key.txt")
      iv_file = input.gsub(input_extension, "_iv.txt")
      
      key_text = File.read(key_file)
      iv_text = File.read(iv_file)
      
      key = asymmetric_decryption(pem_file, password, key_text)
      iv = asymmetric_decryption(pem_file, password, iv_text)

      cipher = OpenSSL::Cipher::Cipher.new(alg)
      cipher.decrypt
      cipher.key = key
      cipher.iv = iv
      
      symmetric_file_decryption(cipher, input, output)
    end
  end
end