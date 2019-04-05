Pod::Spec.new do |s|
    s.name = 'PuzzleMaker'
    s.version = '1.2.1'
    s.license = 'MIT'
    s.summary = 'Swift framework responsible for generating puzzles from the image'
    s.homepage = 'https://github.com/PGSSoft/PuzzleMaker'
    s.authors = { 'Paweł Kania' => 'pkania@pgs-soft.com' }
    s.source = { :git => 'https://github.com/PGSSoft/PuzzleMaker.git', :tag => s.version }
    s.ios.deployment_target = '8.4'
    s.source_files = 'Sources/{*.swift}'
end
