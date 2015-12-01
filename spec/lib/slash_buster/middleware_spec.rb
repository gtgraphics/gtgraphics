describe SlashBuster::Middleware do
  describe '#call' do
    let :app do
      ->(_env) { [200, {}, ['Success']] }
    end

    subject { described_class.new(app) }

    context 'when URL contains no redundant slashes' do
      ['http://test.com',
       'http://test.com/',
       'http://test.com/some/path',
       'http://test.com?any=param',
       'http://test.com/?any=param',
       'http://test.com/some/path?any=param'].each do |url|
        context "with URL being '#{url}'" do
          let :env do
            Rack::MockRequest.env_for(url)
          end

          let :response do
            subject.call(env)
          end

          it 'responds with 200' do
            expect(response[0]).to eq 200
          end

          it 'responds with application body' do
            expect(response[2]).to eq %w(Success)
          end
        end
      end
    end

    context 'when URL contains redundant slashes' do
      {
        'http://test.com////' => 'http://test.com',
        'http://test.com/some/path/' => 'http://test.com/some/path',
        'http://test.com/some/path////' => 'http://test.com/some/path',
        'http://test.com/some////path' => 'http://test.com/some/path',
        'http://test.com/some/path/?any=param&another=query' =>
          'http://test.com/some/path?any=param&another=query'
      }.each do |url, rewritten_url|
        context "with URL being '#{url}'" do
          let :env do
            Rack::MockRequest.env_for(url)
          end

          let :response do
            subject.call(env)
          end

          it 'responds with 301' do
            expect(response[0]).to eq 301
          end

          it "redirects to #{rewritten_url}" do
            expect(response[1]['Location']).to eq rewritten_url
          end

          it 'responds with empty body' do
            expect(response[2]).to eq []
          end
        end
      end
    end
  end
end
