        it 'keeps only the remaining product in the cart' do
          subject
          expect(json_body['data']['relationships']['cart_items'].count).to eq(1)
          expect(json_body['data']['relationships']['cart_items'][0]['product_id']).to eq(product_2.id)
        end