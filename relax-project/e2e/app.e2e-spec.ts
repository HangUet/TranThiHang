import { RelaxProjectPage } from './app.po';

describe('relax-project App', () => {
  let page: RelaxProjectPage;

  beforeEach(() => {
    page = new RelaxProjectPage();
  });

  it('should display welcome message', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('Welcome to app!!');
  });
});
