import GamesShowContainer from '../../src/containers/GamesShowContainer';
import PieceTile from '../../src/components/PieceTile';


describe('GamesShowContainer', () => {
  let wrapper;
  beforeEach(() => {

    spyOn(GamesShowContainer.prototype, 'componentDidMount')
    wrapper = mount(
      <GamesShowContainer
        params={{id: 1}}
      />
    )
  })
  it('should have state board', () => {
  expect(wrapper).toHaveState('board');
  });

  it('should have state coordinates', () => {
  expect(wrapper).toHaveState('coordinates');
  });

  it('should have state message', () => {
  expect(wrapper).toHaveState('message');
  });

  it('should have state turn', () => {
  expect(wrapper).toHaveState('turn');
  });

  it('should have state winner', () => {
  expect(wrapper).toHaveState('winner');
  });

  it('should have state team', () => {
  expect(wrapper).toHaveState('team');
  });

  it('should have state redplayers', () => {
  expect(wrapper).toHaveState('redplayers');
  });

  it('should have state blackplayers', () => {
  expect(wrapper).toHaveState('blackplayers');
  });

  it('should have state name', () => {
  expect(wrapper).toHaveState('name');
  });

  it('should render a h1 tag', () => {
  expect(wrapper.find('h1').text()).toBe ("Title:");
  });


  describe('it should render a game', () => {
    beforeEach(() => {
    let name = "test"
    wrapper.setState({ name: "test"})
    })
    it('should render the game name', () => {
      expect(wrapper.text()).toMatch("test")
    })

  })
});
