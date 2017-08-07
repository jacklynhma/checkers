import GamesShowContainer from '../../src/containers/GamesShowContainer';
import PieceTile from '../../src/components/PieceTile';
import NavBar from '../../src/components/NavBar';

describe('GamesShowContainer', () => {
  let wrapper;
  beforeEach(() => {
      wrapper = mount( <GamesShowContainer />)
  });
  it('should have state board', () => {
  expect(wrapper).toHaveState('coordinates')
  })
});
