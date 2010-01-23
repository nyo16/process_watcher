#--
# Copyright: Copyright (c) 2010 RightScale, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to 
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module RightScale

  # Hash of repository types associated with corresponding scraper class
  SCRAPERS = { 'git'      => RightScale::GitScraper,
               'svn'      => RightScale::SvnScraper,
               'download' => RightScale::DownloadScraper }

  # Library main entry point. Instantiate this class and call the scrape
  # method to download or update a remote repository to the local disk.
  class Scraper

    # (String) Path to directory where remote repository was downloaded
    # Note: This will be a subfolder of the scrape directory (directory given to initializer)
    attr_reader :repo_dir
    
    # Initialize scrape destination directory
    #
    # === Parameters
    # scrape_dir(String):: Scrape destination directory
    def initialize(scrape_dir)
      @scrape_dir = scrape_dir
      @scrapers = {}
    end

    # Scrape given repository.
    # Create unique directory inside scrape directory when called for the first time.
    # Update content of unique directory incrementally when possible with further calls.
    #
    # === Parameters
    # repo(Hash|RightScale::Repository):: Repository to be scraped
    # Note: repo can either be a Hash or a RightScale::Repo instance.
    # See the RightScale::Repo class for valid Hash keys.
    #
    # === Block
    # If a block is given, it will be called back with progress information
    # the block should take two arguments:
    # - first argument is the string containing the info
    # - second argument is a boolean indicating whether to increment progress
    # The block is called exactly once with the increment flag set to true
    #
    # === Return
    # true:: If scrape was successful
    # false:: If scrape failed, call error_message for information on failure
    #
    # === Raise
    # 'Invalid repository type':: If repository type is not known
    def scrape(repo, &callback)
      repo = RightScale::Repository.from_hash(repo) if repo.is_a?(Hash)
      raise "Invalid repository type" unless SCRAPERS.include?(repo.repo_type)
      @scraper = @scrapers[repo.repo_type] ||= SCRAPERS[repo.repo_type].new(@scrape_dir)
      @scraper.scrape(repo, &callback)
      @repo_dir = @scraper.repo_dir
      @scraper.succeeded?
    end

    # Error messages in case of failure
    #
    # === Return
    # errors(Array):: Error messages or empty array if no error
    def errors
      errors = @scraper && @scraper.errors || []
    end

    # Was scraping successful?
    # Call error_message to get error messages if false
    #
    # === Return
    # succeeded(Boolean):: true if scrape finished with no error, false otherwise.
    def succeeded?
      succeeded = @errors.nil? || @errors.size == 0
    end
  end
end
