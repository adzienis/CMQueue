
deploy:
	git rebase master production && \
	git checkout master && \
	git push origin production --force  
	
